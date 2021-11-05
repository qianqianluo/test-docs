
========================================================
Tigase Advanced Clustering Strategy (ACS)--Version 3.2.0
========================================================
1. Design and implementation
============================

1.1. ACS
--------

ACS is our general purpose, commercial clustering strategy designed for more or less typical XMPP installations easily scaling to millions and beyond of online users without limit on cluster nodes. The load tests we have run over the code were included a user database with 100mln accounts and an average roster size of up to 150, but that\'s not the limit.

1.2. Design
-----------
The clustering strategy is based on sharing information between cluster nodes about online users. Who is online and where the user is connected. Communication between cluster nodes is processed with the highest priority to ensure minimal delays with online user data population. An efficient synchronization mechanism allows for a minimal traffic between cluster nodes and distributing accurate data about connecting and disconnecting users.

2. Tigase ACS SM Installation
=============================

Tigase ACS SM component is by default provided with Tigase XMPP Server release (@-dist-max@ flavour of archive) so it\'s enough to enable it in the configuration. It can be also obtained from tigase-acs distribution package.

After downloading the archive it\'s simply matter of extracting it and copying contents of jars/ directory of extracted archive to the jars/ directory in tigase-server/ installation directory, eg. under \*nix systems (assuming the archive was downloaded to main Tigase Server directory):

.. code-block:: bash

   tar -xf tigase-acs-${version}.tar.gz
   cp -R tigase-acs-${version}/jars/ tigase-server/jars/

3. Tigase ACS SM Configuration
==============================

In order to user Advanced Clustering Strategy, clustering mode first needs to be turned on:

.. code-block:: bash

   'cluster-mode' = true

and then an ACS strategy needs to be enabled:

.. code-block:: bash

   'sess-man' {
    strategy (class: tigase.server.cluster.strategy.OnlineUsersCachingStrategy) {}
    }

4. Supported components
=======================

4.1. Tigase Advanced Clustering Strategy for Multi User Chat (ACS-MUC)
----------------------------------------------------------------------

4.1.1. Overview
^^^^^^^^^^^^^^^

ACS for MUC allows seamless clustering of MUC rooms across Tigase XMPP server cluster installation. ACS for MUC is required for clustered MUC deployments. If offers various strategies to handle distribution of traffic and rooms across the cluster, which allows fine-tune configuration of the deployment to individual needs.

4.1.2. Tigase ACS MUC Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In order to use ACS for MUC, main Advance Clustering Strategy is required. Once it\'s enabled, clustered version of MUC component will be selected by default during startup therefore it\'s not required to configure it explicitly (make sure no class is configured).

.. code-block:: bash

   muc () {}

It\'s also possible to explicitly configure the class with the following configuration:

.. code-block:: bash

   muc (class: tigase.muc.cluster.MUCComponentClustered) {}

With the above configuration default MUC clustering strategy will be used. In order to select different strategy you have to configure it\'s class in strategy bean within muc component bean:

.. code-block:: bash

   muc () {
     strategy (class: tigase.muc.cluster.ShardingStrategy) {}
   }


