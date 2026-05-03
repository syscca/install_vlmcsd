# install_vlmcsd
Debian 13 vlmcsd 一键安装脚本

保存为 install_vlmcsd.sh，然后执行：

chmod +x install_vlmcsd.sh

sudo ./install_vlmcsd.sh

卸载密钥
slmgr /upk

安装Windows 11 Pro 密钥
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX

设置KMS密钥服务器
slmgr /skms <debian 13 ip>

激活
slmgr /ato

详细授权信息
slmgr /dlv 
