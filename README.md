knaou/Postfix
====================

Postfix with simple configulation for small service.

```
version: "3"
services:
  smtp:
    image: knaou/postfix
    ports:
      - 127.0.0.1:1025:25
    volumes:
      - ./log:/var/log
      - ./data:/var/postfix
    environment:
      MYHOSTNAME: mail.example.com
      MYDOMAIN: example.com
      # RELAY_TO: "mailserver:465"
      # RELAY_USERNAME: "username" 
      # RELAY_PASSWORD: "password" 
```
