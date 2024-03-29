FROM python:3.6.4-alpine3.6

ENV FLASK_APP=cap_demo_app
COPY . /app
WORKDIR /app

RUN pip install --upgrade pip &&  pip install --editable .
RUN flask initdb

EXPOSE 5000
CMD [ "flask", "run", "--host=0.0.0.0" ]



