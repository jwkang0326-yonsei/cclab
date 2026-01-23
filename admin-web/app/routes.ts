
/**
 * Application Routes Configuration
 */
import {
  type RouteConfig,
  index,
  layout,
  prefix,
  route,
} from "@react-router/dev/routes";

export default [
  route("/robots.txt", "core/screens/robots.ts"),
  route("/sitemap.xml", "core/screens/sitemap.ts"),
  route("/invite/:code", "features/links/screens/invite-redirect.tsx"),
  ...prefix("/debug", [
    route("/sentry", "debug/sentry.tsx"),
    route("/analytics", "debug/analytics.tsx"),
  ]),
  // API Routes.
  ...prefix("/api", [
    ...prefix("/settings", [
      route("/theme", "features/settings/api/set-theme.tsx"),
      route("/locale", "features/settings/api/set-locale.tsx"),
    ]),
  ]),

  layout("core/layouts/navigation.layout.tsx", [
    index("features/home/screens/home.tsx"),
    route("/error", "core/screens/error.tsx"),
  ]),

  layout("core/layouts/public.layout.tsx", [
    route("/login", "features/auth/screens/login.tsx"),
  ]),

  layout("core/layouts/private.layout.tsx", [
    route("/dashboard", "features/users/screens/dashboard.tsx"),
    route("/members", "features/users/screens/member-list.tsx"),
    route("/goals", "features/goals/screens/goal-list.tsx"),
    ...prefix("/groups", [
      index("features/groups/screens/group-list.tsx"),
      route("/:groupId", "features/groups/screens/group-detail.tsx"),
    ]),
  ]),

] satisfies RouteConfig;
