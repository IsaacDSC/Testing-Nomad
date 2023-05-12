job "example" {
  datacenters = ["*"]
  type = "service"
  update {

    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  migrate {
    max_parallel = 1

    # Specifies the mechanism in which allocations health is determined. The
    # potential values are "checks" or "task_states".
    health_check = "checks"

    # Specifies the minimum time the allocation must be in the healthy state
    # before it is marked as healthy and unblocks further allocations from being
    # migrated. This is specified using a label suffix like "30s" or "15m".
    min_healthy_time = "10s"

    # Specifies the deadline in which the allocation must be marked as healthy
    # after which the allocation is automatically transitioned to unhealthy. This
    # is specified using a label suffix like "2m" or "1h".
    healthy_deadline = "5m"
  }
  # The "group" block defines a series of tasks that should be co-located on
  # the same Nomad client. Any task within a group will be placed on the same
  # client.
  #
  # For more information and examples on the "group" block, please see
  # the online documentation at:
  #
  #     https://www.nomadproject.io/docs/job-specification/group
  #
  group "cache" {
    # The "count" parameter specifies the number of the task groups that should
    # be running under this group. This value must be non-negative and defaults
    # to 1.
    count = 1

    # The "network" block specifies the network configuration for the allocation
    # including requesting port bindings.
    #
    # For more information and examples on the "network" block, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/network
    #
    network {
      port "db" {
        to = 6379
      }
    }

    # The "service" block instructs Nomad to register this task as a service
    # in the service discovery engine, which is currently Nomad or Consul. This
    # will make the service discoverable after Nomad has placed it on a host and
    # port.
    #
    # For more information and examples on the "service" block, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/service
    #
    service {
      name     = "redis-cache"
      tags     = ["global", "cache"]
      port     = "db"
      provider = "nomad"

      # The "check" block instructs Nomad to create a Consul health check for
      # this service. A sample check is provided here for your convenience;
      # uncomment it to enable it. The "check" block is documented in the
      # "service" block documentation.

      # check {
      #   name     = "alive"
      #   type     = "tcp"
      #   interval = "10s"
      #   timeout  = "2s"
      # }

    }

    # The "restart" block configures a group's behavior on task failure. If
    # left unspecified, a default restart policy is used based on the job type.
    #
    # For more information and examples on the "restart" block, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/restart
    #
    restart {
      # The number of attempts to run the job within the specified interval.
      attempts = 2
      interval = "30m"

      # The "delay" parameter specifies the duration to wait before restarting
      # a task after it has failed.
      delay = "15s"

      # The "mode" parameter controls what happens when a task has restarted
      # "attempts" times within the interval. "delay" mode delays the next
      # restart until the next interval. "fail" mode does not restart the task
      # if "attempts" has been hit within the interval.
      mode = "fail"
    }

    # The "ephemeral_disk" block instructs Nomad to utilize an ephemeral disk
    # instead of a hard disk requirement. Clients using this block should
    # not specify disk requirements in the resources block of the task. All
    # tasks in this group will share the same ephemeral disk.
    #
    # For more information and examples on the "ephemeral_disk" block, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/ephemeral_disk
    #
    ephemeral_disk {
      # When sticky is true and the task group is updated, the scheduler
      # will prefer to place the updated allocation on the same node and
      # will migrate the data. This is useful for tasks that store data
      # that should persist across allocation updates.
      # sticky = true
      #
      # Setting migrate to true results in the allocation directory of a
      # sticky allocation directory to be migrated.
      # migrate = true
      #
      # The "size" parameter specifies the size in MB of shared ephemeral disk
      # between tasks in the group.
      size = 300
    }

    # The "affinity" block enables operators to express placement preferences
    # based on node attributes or metadata.
    #
    # For more information and examples on the "affinity" block, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/affinity
    #
    # affinity {
    # attribute specifies the name of a node attribute or metadata
    # attribute = "${node.datacenter}"


    # value specifies the desired attribute value. In this example Nomad
    # will prefer placement in the "us-west1" datacenter.
    # value  = "us-west1"


    # weight can be used to indicate relative preference
    # when the job has more than one affinity. It defaults to 50 if not set.
    # weight = 100
    #  }


    # The "spread" block allows operators to increase the failure tolerance of
    # their applications by specifying a node attribute that allocations
    # should be spread over.
    #
    # For more information and examples on the "spread" block, please
    # see the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/spread
    #
    # spread {
    # attribute specifies the name of a node attribute or metadata
    # attribute = "${node.datacenter}"


    # targets can be used to define desired percentages of allocations
    # for each targeted attribute value.
    #
    #   target "us-east1" {
    #     percent = 60
    #   }
    #   target "us-west1" {
    #     percent = 40
    #   }
    #  }

    # The "task" block creates an individual unit of work, such as a Docker
    # container, web application, or batch processing.
    #
    # For more information and examples on the "task" block, please see
    # the online documentation at:
    #
    #     https://www.nomadproject.io/docs/job-specification/task
    #
    task "redis" {
      # The "driver" parameter specifies the task driver that should be used to
      # run the task.
      driver = "docker"

      # The "config" block specifies the driver configuration, which is passed
      # directly to the driver to start the task. The details of configurations
      # are specific to each driver, so please see specific driver
      # documentation for more information.
      config {
        image = "redis:7"
        ports = ["db"]

        # The "auth_soft_fail" configuration instructs Nomad to try public
        # repositories if the task fails to authenticate when pulling images
        # and the Docker driver has an "auth" configuration block.
        auth_soft_fail = true
      }

      # The "artifact" block instructs Nomad to download an artifact from a
      # remote source prior to starting the task. This provides a convenient
      # mechanism for downloading configuration files or data needed to run the
      # task. It is possible to specify the "artifact" block multiple times to
      # download multiple artifacts.
      #
      # For more information and examples on the "artifact" block, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/artifact
      #
      # artifact {
      #   source = "http://foo.com/artifact.tar.gz"
      #   options {
      #     checksum = "md5:c4aa853ad2215426eb7d70a21922e794"
      #   }
      # }

      # The "logs" block instructs the Nomad client on how many log files and
      # the maximum size of those logs files to retain. Logging is enabled by
      # default, but the "logs" block allows for finer-grained control over
      # the log rotation and storage configuration.
      #
      # For more information and examples on the "logs" block, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/logs
      #
      # logs {
      #   max_files     = 10
      #   max_file_size = 15
      # }

      # The "identity" block instructs Nomad to expose the task's workload
      # identity token as an environment variable and in the file
      # secrets/nomad_token.
      identity {
        env  = true
        file = true
      }

      # The "resources" block describes the requirements a task needs to
      # execute. Resource requirements include memory, cpu, and more.
      # This ensures the task will execute on a machine that contains enough
      # resource capacity.
      #
      # For more information and examples on the "resources" block, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/resources
      #
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }


      # The "template" block instructs Nomad to manage a template, such as
      # a configuration file or script. This template can optionally pull data
      # from Consul or Vault to populate runtime configuration data.
      #
      # For more information and examples on the "template" block, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/template
      #
      # template {
      #   data          = "---\nkey: {{ key \"service/my-key\" }}"
      #   destination   = "local/file.yml"
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # The "template" block can also be used to create environment variables
      # for tasks that prefer those to config files. The task will be restarted
      # when data pulled from Consul or Vault changes.
      #
      # template {
      #   data        = "KEY={{ key \"service/my-key\" }}"
      #   destination = "local/file.env"
      #   env         = true
      # }

      # The "vault" block instructs the Nomad client to acquire a token from
      # a HashiCorp Vault server. The Nomad servers must be configured and
      # authorized to communicate with Vault. By default, Nomad will inject
      # The token into the job via an environment variable and make the token
      # available to the "template" block. The Nomad client handles the renewal
      # and revocation of the Vault token.
      #
      # For more information and examples on the "vault" block, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/vault
      #
      # vault {
      #   policies      = ["cdn", "frontend"]
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # Controls the timeout between signalling a task it will be killed
      # and killing the task. If not set a default is used.
      # kill_timeout = "20s"
    }
  }
}
