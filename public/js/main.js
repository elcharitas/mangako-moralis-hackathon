import {
  Router,
  ContainerRouteRenderer,
} from "https://unpkg.com/route-it@1.1.0/dist/index.js";

const parent = document.querySelector("#content");
const container = new ContainerRouteRenderer(parent);

const partials = {};

const sharedData = {
  sign_in: "Sign In",
};

const sharedMethods = {
  connect_wallet() {
    Moralis.authenticate();
  },
  change_blockchain(id) {},
};

function getQuery(name, def) {
  return new URLSearchParams(location.search).get(name) ?? def;
}

function compile(templateId, data, router) {
  // boot the template
  const template = document.getElementById(templateId);
  if (!template) return getErrorPage({ templateId }, router);

  const output = document.createElement("div");
  output.id = `mgk-${Math.floor(Math.random() * 100)}`;

  setTimeout(
    () =>
      Ractive({
        target: `#${output.id}`,
        template: template.innerHTML.replace("&gt;", ">"),
        data,
        partials,
      }).on(
        Object.assign(
          {
            getId: () => output.id,
            navigate: (_, path) => router.navigate(path),
          },
          sharedMethods
        )
      ),
    5
  );

  return output;
}

function getErrorPage(data, router) {
  return compile("page-template-error", data, router);
}

class Routes {
  resolve(_lastRoute, currentRoute, router) {
    const route = currentRoute.replace(/\//, "page-template-");
    const routeId = route === "page-template-" ? route + "home" : route;
    return compile(routeId, sharedData, router);
  }
}

Ractive.DEBUG = false;

document.onreadystatechange = function () {
  if (document.readyState === "complete") {
    for (let partial of document
      .getElementById("page-partials")
      .content.querySelectorAll(".page-partial"))
      partials[partial.id] = partial.innerHTML;

    Moralis.start({
      appId: "80inKfDt5UEbn8MFwQxTpZxcj3riwdDtUeEuijZj",
      serverUrl: "https://nakadxaap66l.usemoralis.com:2053/server",
    });

    const router = new Router(new Routes(), container);
    document.body.prepend(compile("page-header", sharedData, router));
    router.run();
  }
};
