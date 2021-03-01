---
layout: single
title: Countries
sidebar:
  nav: home
classes: wide
---
{% assign country_pages = site.country | sort: 'title' %}
{% assign country_list = site.data.Countries | sort: 'Name' %}
Below, please find per-country pages, and per-country data sheets.

## Profile Pages
<a href="/">how to add a profile page</a>

{% for country in country_pages %} <a href="/country/{{ country.country.key | relative_url }}">{{ country.title }}</a> {% endfor %}

## Data Sheet
{% for country in country_list %} <a href="{{ country.link | relative_url }}">{{ country.Name | lowercase }}</a> {% endfor %}

## Tell the community about something
Add a URL or make a note - we'll integrate this information into the web site.
Please see <a href="/">Particiaption<a> for information about how to share
information via github.
<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSc1d_tTKAMfdqK4gXtajdCSQ1X4i6dM4WXlAFf8qb8qhFnbjA/viewform?embedded=true" width="640" height="705" frameborder="0" marginheight="0" marginwidth="0">Loading…</iframe>

## Mapping

| Priority apples | Second priority | Third priority |
|-------|--------|---------|
{% for country in country_list %}| {{ country.Name }} | {{ country.Name | strip_guid }} | {{ country.Name }} |
{% endfor %}

## Kumu
<iframe src="https://embed.kumu.io/3acd9c750afde2aec00498f5c999f950" width="940" height="600" frameborder="0"></iframe>
