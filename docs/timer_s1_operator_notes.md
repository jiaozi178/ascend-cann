**工作目录为：`/ddhome/timers1_xxx`，需要按实际环境替换。**

## 环境准备

```bash
docker run -it -d --net=host --shm-size=500g \
    --privileged \
    --name timers1_xxx \
    --device=/dev/davinci_manager \
    --device=/dev/hisi_hdc \
    --device=/dev/devmm_svm \
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
    -v /usr/local/sbin:/usr/local/sbin \
    -v /ddhome:/ddhome \
    ljm_env bash
```

```bash
docker start timers1_xxx
docker exec -it timers1_xxx bash
```

```bash
conda create --name xxx --clone timers1_ljm
conda activate timers1_xxx
```

CANN 下载地址：

- https://www.hiascend.com/cann/download
- https://www.hiascend.com/developer/download/community/result?module=cann&cann=8.5.0

```bash
# 安装 CANN
cd /ddhome/timers1_xxx/
rm -rf /ddhome/timers1_xxx/Ascend

wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.0/Ascend-cann-toolkit_8.5.0_linux-aarch64.run
chmod +x Ascend-cann-toolkit_8.5.0_linux-aarch64.run

wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.5.T63/Ascend-cann-910b-ops_8.5.0_linux-aarch64.run
chmod +x Ascend-cann-910b-ops_8.5.0_linux-aarch64.run

mkdir /ddhome/timers1_xxx/Ascend
chmod 755 /ddhome/timers1_xxx
chmod 755 /ddhome/timers1_xxx/Ascend

./Ascend-cann-toolkit_8.5.0_linux-aarch64.run --install --install-path=/ddhome/timers1_xxx/Ascend --quiet
./Ascend-cann-910b-ops_8.5.0_linux-aarch64.run --install --install-path=/ddhome/timers1_xxx/Ascend --quiet
```

```bash
# 克隆 ops-nn 仓库
cd /ddhome/timers1_xxx/
git clone https://gitcode.com/cann/ops-nn.git
cd ./ops-nn
git checkout 8.5.0
```

```bash
# 安装基础依赖
which file
sudo apt-get update && sudo apt-get install -y file

pip install mindinsight
pip install msprof-analyze
```

## silumul

### 编译测试

```bash
conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

cd /ddhome/timers1_xxx/ops-nn
rm -rf build output build_out
bash build.sh --pkg --soc=ascend910b --ops=silu_mul
```

```bash
# 生成包
cd /ddhome/timers1_xxx/ops-nn/build
make package
```

```bash
# 安装编译后包
/ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn/scripts/uninstall.sh
rm -rf /ddhome/timers1_xxx/tmp_install
mkdir -p /ddhome/timers1_xxx/tmp_install
/ddhome/timers1_xxx/ops-nn/build_out/cann-ops-nn-custom-linux.aarch64.run
```

```bash
# 仓库测试
cd /ddhome/timers1_xxx/ops-nn
pip3 install -r tests/requirements.txt
bash build.sh -u --ops=silu_mul
```

### mindspore 测试

```bash
cd /ddhome/timers1_xxx/silumul_mindspore

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

python run_test.py
python model_test.py
python net_test.py
python profiling_silumul.py
```

### torch 测试

```bash
cd /ddhome/timers1_xxx/silumul_torch

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_silu_mul.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name libcust_opapi.so

python setup.py
python test_silu_mul.py
```

## splitop

### 模型分析

```bash
cd /ddhome/timers1_xxx/timers1_model

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh
rm -rf ./prof_timer_s1

python timer_s1_simpletest.py
python timer_s1_profiler.py

msprof-analyze advisor all -d ./prof_timer_s1
```

### 算子编译测试

```bash
cd /ddhome/timers1_xxx/splitop

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh
```

```bash
# 编译
cd /ddhome/timers1_xxx/ops-nn
rm -rf build output build_out
bash build.sh --pkg --soc=ascend910b --ops=mat_mul_v3,swi_glu
```

```bash
# 生成包
cd /ddhome/timers1_xxx/ops-nn/build
make package
```

```bash
# 安装编译后包
/ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn/scripts/uninstall.sh
rm -rf /ddhome/timers1_xxx/tmp_install
mkdir -p /ddhome/timers1_xxx/tmp_install
/ddhome/timers1_xxx/ops-nn/build_out/cann-ops-nn-custom-linux.aarch64.run
```

```bash
# 安装 Python 扩展
cd /ddhome/timers1_xxx/splitop

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_matmul.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_swi_glu.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name libcust_opapi.so

python setup_ops_nn_ext.py
python test_ops_nn_ext.py
```

### 模拟测试

```bash
cd /ddhome/timers1_xxx/timers1_model

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

python timer_s1_splitopsimulate.py
```

### 模型测试

```bash
cd /ddhome/timers1_xxx/timers1_model

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

python timer_s1_splitopmodel.py
```

## customop

```bash
conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh
```

```bash
# 编译
cd /ddhome/timers1_xxx/ops-nn
rm -rf build output build_out
bash build.sh --pkg --soc=ascend910b --ops=swiglu_gated_mlp
```

```bash
# 生成包
cd /ddhome/timers1_xxx/ops-nn/build
make package
```

```bash
# 安装编译后包
/ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn/scripts/uninstall.sh
rm -rf /ddhome/timers1_xxx/tmp_install
mkdir -p /ddhome/timers1_xxx/tmp_install
/ddhome/timers1_xxx/ops-nn/build_out/cann-ops-nn-custom-linux.aarch64.run
```

## 算子单测

```bash
cd /ddhome/timers1_xxx/customop

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_swiglu_gated_mlp.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name libcust_opapi.so

rm -rf build *.so
python setup_ops_nn_ext.py
python test_ops_nn_ext.py
```

## 总算子

### 算子编译测试

```bash
cd /ddhome/timers1_xxx/allop

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh
```

```bash
# 编译
cd /ddhome/timers1_xxx/ops-nn
rm -rf build output build_out
bash build.sh --pkg --soc=ascend910b --ops=mat_mul_v3,swi_glu,swiglu_gated_mlp
```

```bash
# 生成包
cd /ddhome/timers1_xxx/ops-nn/build
make package
```

```bash
# 安装编译后包
/ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn/scripts/uninstall.sh
rm -rf /ddhome/timers1_xxx/tmp_install
mkdir -p /ddhome/timers1_xxx/tmp_install
/ddhome/timers1_xxx/ops-nn/build_out/cann-ops-nn-custom-linux.aarch64.run
```

```bash
# 安装 Python 扩展并做综合测试
cd /ddhome/timers1_xxx/allop

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_matmul.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_swi_glu.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name aclnn_swiglu_gated_mlp.h
find /ddhome/timers1_xxx/Ascend/cann-8.5.0/opp/vendors/custom_nn -name libcust_opapi.so

rm -rf build *.so
python setup_ops_nn_ext.py
python test_ops_nn_ext.py
```

### 模型测试

```bash
cd /ddhome/timers1_xxx/timers1_model

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

python timer_s1_allopmodel.py
```

### UT测试

```bash
# 编译
cd /ddhome/timers1_xxx/ops-nn

conda activate timers1_xxx
source /ddhome/timers1_xxx/Ascend/cann-8.5.0/set_env.sh

rm -rf build output build_out
bash build.sh --pkg --soc=ascend910b --ops=swiglu_gated_mlp

pip3 install -r tests/requirements.txt
bash build.sh -u --ops=swiglu_gated_mlp
```

