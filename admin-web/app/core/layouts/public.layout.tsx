
import type { Route } from "./+types/public.layout";
import { Outlet, useNavigate } from "react-router";
import { useEffect, useState } from "react";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "~/services/firebase";

export async function loader({ request }: Route.LoaderArgs) {
    return {};
}

export default function PublicLayout() {
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (user) => {
            if (user) {
                navigate("/dashboard");
            }
            setLoading(false);
        });
        return () => unsubscribe();
    }, [navigate]);

    if (loading) {
        return <div className="flex h-screen items-center justify-center">Loading...</div>;
    }

    return <Outlet />;
}
