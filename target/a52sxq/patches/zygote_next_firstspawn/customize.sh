# NativeZygoteProcess (framework.jar) talks to zygote_next over a LocalSocket and reads the spawn reply with a plain
# blocking read() in libandroid_runtime's ReadSpawnResponse. A native child zygote that dies before answering (on
# 2026-10-07: a test app declaring android:nativeService without zygotePreloadNativeLib / native service library
# properties) leaves ActivityManager:procStart blocked forever -> "Blocked in handler on ActivityManager:procStart for
# 70s" -> watchdog restarts system_server. ReadSpawnResponse treats read() == -1 as an error and throws IOException,
# which startChildZygote already catches (logs, returns null = service start fails). So:
#  1. connectToZygote(): after connect(), setSoTimeout(20000) (SO_RCVTIMEO) on the socket.
#  2. startChildZygote(): in its IOException handler, close and drop mSocket so a late reply is never read as the
#     answer to the next spawn request (the next call reconnects).
DECODE_APK "system" "system/framework/framework.jar"
python3 - "$APKTOOL_DIR/system/framework/framework.jar" << 'PYEOF' || ABORT "Failed to apply the native zygote spawn timeout"
import glob, re, sys
f = glob.glob(sys.argv[1] + "/smali*/android/os/NativeZygoteProcess.smali")
assert len(f) == 1, "NativeZygoteProcess.smali"
s = open(f[0]).read()
SOCK = "Landroid/os/NativeZygoteProcess;->mSocket:Landroid/net/LocalSocket;"

# 1. connectToZygote: set a receive timeout right after a successful connect (inside the existing IOException try).
old = ("    invoke-virtual {v0, v1}, Landroid/net/LocalSocket;->connect(Landroid/net/LocalSocketAddress;)V\n")
new = old + ("\n    const/16 v1, 0x4e20\n\n"
             "    invoke-virtual {v0, v1}, Landroid/net/LocalSocket;->setSoTimeout(I)V\n")
start = s.index(".method private declared-synchronized blacklist connectToZygote()V")
end = s.index(".end method", start)
body = s[start:end]
assert body.count(old) == 1, "connectToZygote connect call"
assert "setSoTimeout" not in body, "already patched"
s = s[:start] + body.replace(old, new) + s[end:]

# 2. startChildZygote: reset the socket in the IOException handler.
start = s.index(".method public blacklist startChildZygote(")
end = s.index(".end method", start)
body = s[start:end]
m = re.search(r"\n    :catch_0\n    move-exception v0\n", body)
assert m and body.count(":catch_0\n    move-exception") == 1, "startChildZygote catch block"
assert re.search(r"\.locals (\d+)", body) and int(re.search(r"\.locals (\d+)", body).group(1)) >= 3, "locals"
reset = ("\n    move-object/from16 v2, p0\n\n"
         "    iget-object v1, v2, " + SOCK + "\n\n"
         "    if-eqz v1, :unica_nz_reset_done\n\n"
         "    :try_start_unica_nz\n"
         "    invoke-virtual {v1}, Landroid/net/LocalSocket;->close()V\n"
         "    :try_end_unica_nz\n"
         "    .catch Ljava/io/IOException; {:try_start_unica_nz .. :try_end_unica_nz} :unica_nz_close_failed\n\n"
         "    :unica_nz_close_failed\n"
         "    const/4 v1, 0x0\n\n"
         "    iput-object v1, v2, " + SOCK + "\n\n"
         "    :unica_nz_reset_done\n")
body = body[:m.end()] + reset + body[m.end():]
s = s[:start] + body + s[end:]
open(f[0], "w").write(s)
PYEOF
LOG "- Native zygote spawns time out after 20 s instead of blocking system_server"
