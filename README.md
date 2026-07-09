# ruby-df-slim-multistage  (✅)

Bölüm 6 — Dockerfile varyantı: `ruby:3.x-slim` multi-stage (bundle install + assets:precompile),
glibc trusted-source (debian). Build + run.

Not: production.rb'de `config.assume_ssl = true` açık ve Dockerfile `SECRET_KEY_BASE` set
ediyor — böylece Rails 7.2 prod SSL/secret confound'u nötrlenip test yalnız
slim/multistage/glibc değişkenini ölçüyor (komuta Rails-prod gap'i Bölüm 3-5'te belgeli).
