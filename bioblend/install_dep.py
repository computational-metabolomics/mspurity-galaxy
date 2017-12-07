import bioblend.galaxy

url = 'http://0.0.0.0:8888'
api_key = 'a28a3077e8dae9136d395a0d003d3723'
tools = ["spectral_matching"]
gi = bioblend.galaxy.GalaxyInstance(url, api_key)
gi.verify = False

for tool in tools:
    endpoint = "api/tools/{}/install_dependencies".format(tool)
    deps = gi.make_post_request("/".join((url, endpoint)), payload={'id': tool})
    for d in deps:
        print d


