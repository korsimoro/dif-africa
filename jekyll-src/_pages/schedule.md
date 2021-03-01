---
layout: single
title: Meeting Schedule
sidebar:
  nav: home
classes: wide
---
* <a href="https://www.notion.so/1b088f2c46f54050be7f1a4f7edbc226?v=3a13601010de49dd9d4376ca01013748" >Active Schedule and Notion Page</a>
* <a href="Propose a topic" >Propose a Topic</a>
* <a href="https://us02web.zoom.us/j/655628076?pwd=SXc0UlAzSHd0a25rZ1JMazRsS1V3Zz09" >Join Meeting</a>


## Next Meeting
{% assign event = site.data.Schedule | notion_date_select_next: 'When' %}
| When | Days Until | Business | Legal | Social | Country Spotlight |
|----------|---------|-|-|-|-|
| <a href="{{event['Notion Link']}}">{{ event.When }}</a> | {{ event | notion_date_days_until: 'When' }} | {{ event.Business }} | {{ event.Legal }} | {{ event.Social }} | {{ event["Country Spotlight"] }} |
|----------|---------|-|-|-|-|


## Upcoming Meetings
{% assign schedule = site.data.Schedule | notion_date_select_upcoming: 'When' | notion_date_sort: 'When' %}
| When | Responsibility | Country Spotlight | Topics |
|----------|---------|-|-|-|-|
{% for event in schedule %}| <a href="{{event['Notion Link']}}">{{ event.When }}</a> | <a href="{{event.Responsibility}}">{{ event.Responsibility | name_from_notion_link }}</a> | {{ event["Country Summary"] }} | {{ event.what_goes_here }} |
{% endfor %}

## Previous Meetings
{% assign schedule = site.data.Schedule | notion_date_select_history: 'When' | notion_date_sort: 'When' %}
| When | Responsibility | Country Spotlight | Topics |
|----------|---------|-|-|-|-|
{% for event in schedule %}| <a href="{{event['Notion Link']}}">{{ event.When }}</a> | <a href="{{event.Responsibility}}">{{ event.Responsibility | name_from_notion_link }}</a> | {{ event["Country Spotlight"]}}| {{ event.Business }} {{ event.Legal }} {{ event.Social }} |
{% endfor %}
