###
# Copyright (2017) Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###

tag="$1"
if [ "$tag" != "" ]
then
  backup_swarm="-e backup_name=${tag}_swarm"
  backup_ucp="-e backup_name=${tag}_ucp"
  backup_dtr_meta="-e backup_name=${tag}_dtr_meta"
  backup_dtr_data="-e backup_name=${tag}_dtr_data"
else
  backup_swarm=""
  backup_ucp=""
  backup_dtr_meta=""
  backup_dtr_data=""
fi

ansible-playbook -i vm_hosts playbooks/backup_swarm.yml        $backup_swarm 
sleep 20
ansible-playbook -i vm_hosts playbooks/backup_ucp.yml          $backup_ucp
sleep 20
ansible-playbook -i vm_hosts playbooks/backup_dtr_metadata.yml $backup_dtr_meta
sleep 20
ansible-playbook -i vm_hosts playbooks/backup_dtr_images.yml   $backup_dtr_data

