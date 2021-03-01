---
layout: single
title: Countries
sidebar:
  nav: home
classes: wide
---
{% assign company_pages = site.company | sort: 'title' %}
{% assign company_list = site.data.Companies | sort: 'Name' %}
Below, please find per-company pages, and per-company data sheets.

## Profile Pages
<a href="/">how to add a profile page</a>

{% for company in company_pages %} <a href="/company/{{ company.company.key | relative_url }}">{{ company.title }}</a> {% endfor %}

## Data Sheet
{% for company in company_list %} <a href="{{ company.link | relative_url }}">{{ company.Name | lowercase }}</a> {% endfor %}

## Tell the community about something
Add a URL or make a note - we'll integrate this information into the web site.
Please see <a href="/">Particiaption<a> for information about how to share
information via github.
<iframe src="https://docs.google.com/forms/d/e/1FAIpQLSc1d_tTKAMfdqK4gXtajdCSQ1X4i6dM4WXlAFf8qb8qhFnbjA/viewform?embedded=true" width="640" height="705" frameborder="0" marginheight="0" marginwidth="0">Loading…</iframe>

## Mapping

| Priority apples | Second priority | Third priority |
|-------|--------|---------|
{% for company in company_list %}| {{ company.Name }} | {{ company.Name | strip_guid }} | {{ company.Name }} |
{% endfor %}

## Kumu
<iframe src="https://embed.kumu.io/3acd9c750afde2aec00498f5c999f950" width="940" height="600" frameborder="0"></iframe>
