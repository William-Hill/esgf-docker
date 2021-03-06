#!/bin/sh
# shell script to remove an existing Solr shard
#
# example invocation: remove_shard.sh esgf-node.llnl.gov 8985
#
# note: this script is idempotent: it can be run multiple times without consequences

# command line arguments
shard_name=$1
shard_port=$2
shard="$1-$2"

# do not ever remove master or slave shards
if ! [[ $shard_name == 'master' || $shard_name == 'slave' ]]; then

  # delete index directory /esg/solr-index/<host>-<port>/
  if [ -d "/esg/solr-index/${shard}" ]; then
    echo "Deleting shard index directory: /esg/solr-index/${shard}"
    rm -rf /esg/solr-index/${shard}
  fi

  # remove solr-home directory /usr/local/solr-home/<host>-<port>/
  if [ -d "$SOLR_HOME/${shard}" ]; then
    echo "Deleting shard home directory $SOLR_HOME/${shard}"
    rm -rf $SOLR_HOME/${shard}
  fi

  # remove supervisor configuration 
  supervisord_config="/etc/supervisor/conf.d/supervisord.solr_${shard_name}_${shard_port}.conf"
  if [ -f "${supervisord_config}" ]; then
    echo "Deleting supervisord configuration: $supervisord_config"
    rm $supervisord_config

    # remove this program to the solr group
    if grep -q ${shard_name} /etc/supervisor/conf.d/supervisord.solr.conf; then
      echo "Removing $shard from supervisor group 'solr'"
      sed -i '/^programs=/ s/,'${shard_name}'_'${shard_port}'//' /etc/supervisor/conf.d/supervisord.solr.conf
    fi

  fi

  # remove shard from list queried by ESGF search application
  shards_file="/esg/config/esgf_shards_static.xml"
  if grep -q ${shard_port} ${shards_file} ; then
    echo "Removing shard from ${shards_file}"
    # note: must work around the error: "sed: cannot rename /esg/config/sedFvmijX: Device or resource busy"
    sed '/localhost:'${shard_port}'/d' ${shards_file} > ${shards_file}.new
    # call "/bin/cp" since for root cp is aliased to "cp -i" (which asks for confirmation)
    /bin/cp -f ${shards_file}.new ${shards_file}
  fi

fi
