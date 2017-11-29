{%- from "linux/map.jinja" import storage with context %}
{%- if storage.enabled %}

mdadm:
  pkg.installed

{%- for raid_name, raid in storage.raid.iteritems() %}
{%- set raid_name = raid.name|default(raid_name) %}
{%- set level = raid.level %}

raid_{{ raid_name }}:
  raid.present:
    - name: {{ raid_name }}
    - level: {{ level }}
    - run: True
    - devices:
{%- for dev_name in raid.devices %}
      - {{ dev_name }}
{%- endfor  %}


{%- endfor %}

{%- endif %}
