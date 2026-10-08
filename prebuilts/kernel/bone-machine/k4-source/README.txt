Build recipe for prebuilts/kernel/bone-machine/bone-machine_k4btf_a52sxq.zip:
  clone https://github.com/mna08072-cmyk/android_kernel_samsung_sm7325_a52s_5g, copy k4_build.sh + k4-patches/ into it,
  run: K4_BACKPORTS=1 ./k4_build.sh   (pins, toolchain and ReSukiSU commit are inside the script)
