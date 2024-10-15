#!/bin/bash

max_retries=8
retry_count=0
failed_flag=0

# 手動で削除する場合
# echo "RESOURCE_GROUP_NAME:"
# read  resource_group
# echo "VM_NAME:"
# read  vm_name
# echo ":"

# リソースグループ内のすべてのVMを取得
vms=$(az vm list --resource-group rg-set-gitlab-ci-cd --query "[].id" -o tsv)

# VMが存在する場合
if [ -n "$vms" ]; then
  # すべてのVMを削除
  for vm in $vms; do
    az vm delete --ids "$vm" --yes --no-wait
    if [ $? -ne 0 ]; then
      echo "VMの削除に失敗しました: $vm"
      failed_flag=1
    fi
  done
  echo "VMの削除が完了しました"
else
  echo "削除するVMが見つかりません"
fi

sleep 60

disks=$(az disk list --resource-group rg-set-gitlab-ci-cd --query "[].id" -o tsv)

# ディスクが存在する場合
if [ -n "$disks" ]; then
  # すべてのディスクを削除
  for disk in $disks; do
    az disk delete --ids "$disk" --yes --no-wait
    if [ $? -ne 0 ]; then
      echo "ディスクの削除に失敗しました: $disk"
      failed_flag=1
    fi
  done
  echo "OK"
else
  echo "削除するディスクが見つかりません"
fi

while [ $retry_count -lt $max_retries ]; do
  echo "Attempt $(($retry_count + 1)) of $max_retries..."
  
  terraform destroy --auto-approve 1> /dev/null
  if [ $? -eq 0 ]; then
    echo "Terraform destroy completed successfully."
    retry_count=$max_retries
  else
    echo "Terraform destroy failed. Sleep 30sec and Retrying..."
  fi

  sleep 30
  retry_count=$(($retry_count + 1))
done

if [ $retry_count -eq $max_retries ]; then
  echo "Terraform destroy failed after $max_retries attempts."
  failed_flag=1
fi


if [ $failed_flag -eq 1 ]; then
  exit 1
else
  exit 0
fi