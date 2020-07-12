FROM ubuntu:18.04
ADD "https://raw.githubusercontent.com/yusufd89/cc_scripts/master/cc_scripts.sh" "/tmp/cc_scripts.sh"
ADD infinity_loop.sh /tmp/infinity_loop.sh
RUN chmod +x /tmp/infinity_loop.sh
ENTRYPOINT ["/tmp/infinity_loop.sh"]
