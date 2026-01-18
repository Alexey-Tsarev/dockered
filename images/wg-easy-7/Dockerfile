# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM weejewel/wg-easy:7

COPY --from=toolbox \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/envsubst \
    /usr/local/bin/template_envsubst.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=wg_easy_var_cache_apk,target=/var/cache/apk,sharing=private \
    --mount=type=cache,id=wg_easy_var_tmp,target=/var/tmp \
    echo "=> Install packages" && \
        apk add findutils && \
    echo "=> Clean" && \
        clean_and_keep.sh /usr/local/bin/envsubst /usr/local/bin/template_envsubst.sh
