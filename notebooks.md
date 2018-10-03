---
layout: page
title: Notebooks
permalink: /notebooks/
---
  <div class="section no-pad-bot" id="index-banner">
    <div class="container" >

      <h1 class="header center black-text">{{ page.title | escape }}</h1>
      
      <br>
    </div>
  </div>

<div class="row">
  {% for post in site.posts %}
  {% if post.categories contains "notebook" %}
  <div class="col s12">
    <div class="card hoverable">
      <div class="card-content">
        <span id="post-title" class="card-title"><b>{{post.title}}</b></span>
        <p id="post-date">
          <i class="material-icons">date_range</i>
          {{post.date | date: "%d/%m/%Y"}}
        </p>
        <p id="post-content">{{post.excerpt | remove: '<p>' | remove: '</p>'}}</p>
      </div>
      <div class="card-action">
        <a href="{{ post.url | relative_url }}">
          Read More
        </a>
      </div>
    </div>
  </div>
  {% endif %}
  {% endfor %}

  <!-- pagination -->
{% if site.total_pages > 1 %}
  <div class="col s12 center-align">
    <ul class="pagination">
      <li class="{% unless site.previous_page %}disabled{% else %}waves-effect{% endunless %}">
        {% if site.previous_page %}
          <a href="{{ site.previous_page_path | prepend: site.baseurl | replace: '//', '/' }}">
            <i class="material-icons">chevron_left</i>
          </a>
        {% else %}
          <i class="material-icons">chevron_left</i>
        {% endif %}
      </li>


      {% if site.page == 1 %}
        <li class="active teal">
          <a href="#!">1</a>
        </li>
      {% else %}
        <li class="waves-effect">
          <a href="{{ site.baseurl | replace: '//', '/' }}blog">1</a>
        </li>
      {% endif %}

  {% for page in (2..site.total_pages) %}
    {% if page == site.page %}

      <li class="active teal">
        <a href="#!">{{ page }}</a>
      </li>

    {% else %}
      <li class="waves-effect">  
        <a href="{{ site.paginate_path | relative_url | replace: ':num', page }}">
        {{ page }}
        </a>
      </li>
    {% endif %}

  {% endfor %}

      <li class="{% unless site.next_page %}disabled{% else %}waves-effect{% endunless %}">
        {% if site.next_page %}
        <a href="{{ site.next_page_path | prepend: site.baseurl | replace: '//', '/' }}">
          <i class="material-icons">chevron_right</i>
        </a>
        {% else %}
          <i class="material-icons">chevron_right</i>
        {% endif %}
      </li>
    </ul>
  </div>
{% endif %}

</div>
