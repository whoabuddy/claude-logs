---
title: "Archive"
layout: default
permalink: /archive/
---

# All Entries

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}

{% for year in posts_by_year %}
<h2 class="archive-year">{{ year.name }}</h2>
<ul class="archive-list">
  {% for post in year.items %}
  <li class="archive-item">
    <span class="archive-date">{{ post.date | date: "%m-%d" }}</span>
    <a href="{{ post.url | relative_url }}">{{ post.title | remove: "Daily Summary - " }}</a>
  </li>
  {% endfor %}
</ul>
{% endfor %}
