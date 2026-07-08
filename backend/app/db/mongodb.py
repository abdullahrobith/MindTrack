import socket

import dns.resolver
from pymongo import MongoClient

from app.core.config import settings

_custom_resolver = dns.resolver.Resolver(configure=False)
_custom_resolver.nameservers = ["8.8.8.8"]
dns.resolver.get_default_resolver = lambda: _custom_resolver

_original_getaddrinfo = socket.getaddrinfo

def _resolve_mongodb(host, port, family=0, type=0, proto=0, flags=0):
    if host.endswith(".mongodb.net"):
        try:
            answers = _custom_resolver.resolve(host, "A")
            ip = str(answers[0])
            return _original_getaddrinfo(ip, port, family, type, proto, flags)
        except Exception:
            pass
    return _original_getaddrinfo(host, port, family, type, proto, flags)

socket.getaddrinfo = _resolve_mongodb

client = MongoClient(settings.MONGO_URI)
db = client[settings.MONGODB_DATABASE]