import bioblend.galaxy

url = 'http://127.0.0.1:8090'
api_key = '0bc0b2c9b6263516de329f9e3e1b39c3'
tools = ["dims_anticipated_purity"]
gi = bioblend.galaxy.GalaxyInstance(url, api_key)
gi.verify = False

for tool in tools:
    endpoint = "api/tools/{}/install_dependencies".format(tool)
    deps = gi.make_post_request("/".join((url, endpoint)), payload={'id': tool})
    for d in deps:
        print d


