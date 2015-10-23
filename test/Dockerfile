FROM aroygreenfeld/centos7-django:base

WORKDIR ./project_name
ENV DJANGO_SETTINGS_MODULE config.settings.local

# Run tests
ENTRYPOINT ["./manage.py test"]
