
import type { Route } from "./+types/navigation.layout";
import { Outlet } from "react-router";
import Footer from "../components/footer";
import { NavigationBar } from "../components/navigation-bar";

export async function loader({ request }: Route.LoaderArgs) {
  return {};
}

export default function NavigationLayout({ loaderData }: Route.ComponentProps) {
  return (
    <div className="flex min-h-screen flex-col justify-between">
      <NavigationBar loading={false} />
      <div className="mx-auto my-16 w-full max-w-screen-2xl px-5 md:my-32">
        <Outlet />
      </div>
      <Footer />
    </div>
  );
}
