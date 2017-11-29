{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

xfsprogs:
  pkg.installed

{%- for disk_name, disk in storage.extfs.iteritems() %}
{%- set disk_name = disk.name|default(disk_name) %}
{%- set fs_type = disk.get('type', 'ext4') %}
{%- set dev_name = disk_name.split('/')|last %}

mkfs_{{ disk_name }}_{{ fs_type }} :
  module.run:
  - name: extfs.mkfs
  - device: {{ disk_name }}
  - fs_type: {{ fs_type }}
  - unless: "lsblk -fs {{ disk_name }} -o name,fstype | grep -i {{ dev_name }} | grep -i {{ fs_type }}"
  - require:
    - pkg: xfsprogs

{%- endfor %}

{%- endif %}
