# This class represents a Marathon Task.
# See https://mesosphere.github.io/marathon/docs/rest-api.html#get-/v2/tasks for full list of API's methods.
class Marathon::Task < Marathon::Base

  ACCESSORS = %w[ id appId host ports servicePorts version stagedAt startedAt ]

  # Create a new task object.
  # ++hash++: Hash including all attributes
  def initialize(hash, conn = Marathon.connection)
    super(hash, conn, ACCESSORS)
  end

  # Kill the task that belongs to an application.
  # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
  #            after killing the specified tasks.
  def delete!(scale = false)
    new_task = self.class.delete(id, scale, connection)
  end
  alias :kill! :delete!

  def to_s
    "Marathon::Task { :id => #{self.id} :appId => #{appId} :host => #{host} }"
  end

  # Returns a string for listing the task.
  def to_pretty_s
    %Q[
Task ID:    #{id}
App ID:     #{appId}
Host:       #{host}
Ports:      #{(ports || []).join(',')}
Staged at:  #{stagedAt}
Started at: #{startedAt}
Version:    #{version}
    ].strip
  end

  class << self

    # List tasks of all applications.
    # ++status++: Return only those tasks whose status matches this parameter.
    #             If not specified, all tasks are returned. Possible values: running, staging.
    def list(status = nil, conn = Marathon.connection)
      query = {}
      Marathon::Util.add_choice(query, :status, status, %w[running staging])
      json = conn.get('/v2/tasks', query)['tasks']
      json.map { |j| new(j, conn) }
    end

    # List all running tasks for application appId.
    # ++appId++: Application's id
    def get(appId, conn = Marathon.connection)
      json = conn.get("/v2/apps/#{appId}/tasks")['tasks']
      json.map { |j| new(j, conn) }
    end

    # Kill the given list of tasks and scale apps if requested.
    # ++ids++: Id or list of ids with target tasks.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete(ids, scale = false, conn = Marathon.connection)
      query = {}
      query[:scale] = true if scale
      ids = [ids] if ids.is_a?(String)
      conn.post("/v2/tasks/delete", query, :body => {:ids => ids})
    end
    alias :remove :delete
    alias :kill :delete

    # Kill tasks that belong to the application appId.
    # ++appId++: Application's id
    # ++host++: Kill only those tasks running on host host.
    # ++scale++: Scale the app down (i.e. decrement its instances setting by the number of tasks killed)
    #            after killing the specified tasks.
    def delete_all(appId, host = nil, scale = false, conn = Marathon.connection)
      query = {}
      query[:host] = host if host
      query[:scale] = true if scale
      json = conn.delete("/v2/apps/#{appId}/tasks", query)['tasks']
      json.map { |j| new(j, conn) }
    end
    alias :remove_all :delete_all
    alias :kill_all :delete_all
  end

end
