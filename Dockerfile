FROM redis:3

COPY redis-trib.rb /usr/bin/redis-trib.rb
COPY start-redis.sh /start-redis.sh
COPY start-cluster.sh /start-cluster.sh
RUN chmod +x /start-redis.sh
RUN chmod +x /start-cluster.sh

VOLUME ["/data"]

CMD ["/start-redis.sh"]
