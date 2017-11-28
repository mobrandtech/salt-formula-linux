{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

parted:
  pkg.installed

xfsprogs:
  pkg.installed

{%- for disk_name, disk in storage.disk.iteritems() %}
{%- set disk_name = disk.name|default(disk_name) %}

create_disk_label_{{ disk_name }}:
  module.run:
  - name: partition.mklabel
  - device: {{ disk_name }}
  - label_type: {{ disk.get('type', 'dos') }}
  - unless: "fdisk -l {{ disk_name }} | grep -i 'Disklabel type: {{ disk.get('type', 'dos') }}'"
  - require:
    - pkg: parted

{% set end_size = 0 -%}

{%- for partition in disk.get('partitions', []) %}

create_partition_{{ disk_name }}_{{ loop.index }}:
  module.run:
  - name: partition.mkpart
  - device: {{ disk_name }}
  - part_type: primary
  - fs_type: {{ partition.type }}
  - start: {{ end_size }}MB
  - end: {{ end_size + partition.size }}MB
  - unless: "blkid {{ disk_name }}{{ loop.index }} {{ disk_name }}p{{ loop.index }}"
  - require:
    - module: create_disk_label_{{ disk_name }}
    - pkg: xfsprogs

{% set end_size = end_size + partition.size -%}

{%- endfor %}

probe_partions_{{ disk_name }}:
  module.run:
  - name: partition.probe
  - device: {{ disk_name }}

{%- for partition in disk.get('partitions', []) %}

{%- if partition.get('mkfs') and partition.type == "xfs" %}

mkfs_partition_{{ disk_name }}_{{ loop.index }}:
  module.run:
  - name: xfs.mkfs
  - device: {{ disk_name }}{{ loop.index }}
  - unless: "blkid {{ disk_name }}{{ loop.index }} {{ disk_name }}p{{ loop.index }} | grep xfs"
  - require:
    - module: create_partition_{{ disk_name }}_{{ loop.index }}

{%- endif %}

{%- endfor %}

{%- for partition in disk.get('partitions', []) %}

{%- if partition.get('flag') and partition.flag == "boot" %}

parted_set_bootable_{{ disk_name }}_{{ loop.index }}:
  module.run:
  - name: partition.set
  - device: {{ disk_name }}
  - minor: {{ loop.index }}
  - flag: boot
  - state: "on"
  - require:
    - module: create_partition_{{ disk_name }}_{{ loop.index }}

{%- endif %}

{%- endfor %}

{%- endfor %}

{%- endif %}
