{%- from "linux/map.jinja" import storage with context %}

{%- if storage.mount|length > 0 or storage.swap|length > 0 or storage.multipath.enabled or storage.disk|length > 0 or storage.lvm|length > 0 or storage.loopback|length > 0 or storage.raid is defined > 0 or storage.extfs is defined  %}

include:
{%- if storage.loopback|length > 0 %}
- linux.storage.loopback
{%- endif %}
{%- if storage.disk|length > 0 %}
- linux.storage.disk
{%- endif %}
{%- if storage.raid is defined %}
- linux.storage.raid
{%- endif %}
{%- if storage.lvm|length > 0 %}
- linux.storage.lvm
{%- endif %}
{%- if storage.extfs is defined %}
- linux.storage.extfs
{%- endif %}
{%- if storage.mount|length > 0 %}
- linux.storage.mount
{%- endif %}
{%- if storage.swap|length > 0 %}
- linux.storage.swap
{%- endif %}
{%- if storage.multipath.enabled %}
- linux.storage.multipath
{%- endif %}

{%- endif %}
