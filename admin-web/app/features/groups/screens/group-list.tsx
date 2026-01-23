
import type { Route } from "./+types/group-list";
import { Plus } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "~/core/components/ui/button";
import { GroupCard } from "../components/group-card";
import { fetchGroups, type Group } from "../api/groups";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Groups | Admin Web" }];
};

export async function loader({ request }: Route.LoaderArgs) {
    return {};
}

export default function GroupList() {
    const [groups, setGroups] = useState<Group[]>([]);

    useEffect(() => {
        fetchGroups().then(setGroups);
    }, []);

    return (
        <div className="flex-1 space-y-8 p-8 pt-6">
            <div className="flex items-center justify-between space-y-2">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Small Groups</h2>
                    <p className="text-muted-foreground">
                        Manage your church cells and groups here.
                    </p>
                </div>
                <div className="flex items-center space-x-2">
                    <Button>
                        <Plus className="mr-2 h-4 w-4" /> Create Group
                    </Button>
                </div>
            </div>

            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {groups.length === 0 ? (
                    <p className="text-muted-foreground col-span-full">No groups found.</p>
                ) : (
                    groups.map((group) => (
                        <GroupCard
                            key={group.id}
                            id={group.id}
                            name={group.name}
                            leaderName={group.leaderName}
                            memberCount={group.memberCount}
                        />
                    ))
                )}
            </div>
        </div>
    );
}
