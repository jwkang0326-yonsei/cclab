import type { Route } from "./+types/private.layout";
import { Outlet, redirect, useNavigation } from "react-router";
import { useEffect, useState } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "~/services/firebase";
import { NavigationBar } from "../components/navigation-bar";
import { Sidebar } from "../components/sidebar";
import Footer from "../components/footer";

export async function loader({ request }: Route.LoaderArgs) {
    return {};
}

export default function PrivateLayout() {
    const [user, setUser] = useState(auth.currentUser);
    const [loading, setLoading] = useState(true);
    const navigation = useNavigation();

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            setUser(currentUser);
            setLoading(false);

            if (!currentUser) {
                // We can't easily redirect from a client-side effect in a way that React Router 7 
                // handles nicely for loaders/actions without reloading, but window.location works for now
                // or we can use a client-side navigate hook if available in the component context.
                // For smoother DX, we'll let the render logic handle the "not authenticated" state momentarily 
                // or use the navigate function if we imported it.
                // Ideally, we'd use `useNavigate` but `redirect` in loader is better if we had server-side auth.
                // Client-side protection:
                window.location.href = "/login";
            }
        });
        return () => unsubscribe();
    }, []);

    if (loading) {
        return <div className="flex h-screen items-center justify-center">Loading...</div>;
    }


    if (!user) {
        return null; // Will redirect in useEffect
    }

    return (
        <div className="flex min-h-screen flex-col">
            <NavigationBar
                name={user.displayName || user.email?.split('@')[0] || "Admin"}
                email={user.email || ""}
                avatarUrl={user.photoURL}
                loading={false}
            />
            <div className="flex flex-1">
                <aside className="hidden w-64 border-r bg-background md:block">
                    <Sidebar />
                </aside>
                <main className="flex-1">
                    <div className="h-full px-4 py-6 lg:px-8">
                        <Outlet />
                    </div>
                </main>
            </div>
            <Footer />
        </div>
    );
}