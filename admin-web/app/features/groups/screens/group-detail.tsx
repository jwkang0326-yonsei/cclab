
import type { Route } from "./+types/group-detail";
import { ArrowLeft } from "lucide-react";
import { Link } from "react-router";
import { useEffect, useState } from "react";
import { Button } from "~/core/components/ui/button";
import { MemberTable } from "../components/member-table";
import { fetchGroupById, fetchGroupMembers, type Group, type Member } from "../api/groups";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Group Detail | Admin Web" }];
};

export async function loader({ params }: Route.LoaderArgs) {
    return { groupId: params.groupId };
}

export default function GroupDetail({ loaderData }: Route.ComponentProps) {
    const { groupId } = loaderData;
    const [group, setGroup] = useState<Group | null>(null);
    const [members, setMembers] = useState<Member[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function loadData() {
            if (!groupId) return;
            const [groupData, membersData] = await Promise.all([
                fetchGroupById(groupId),
                fetchGroupMembers(groupId)
            ]);
            setGroup(groupData);
            setMembers(membersData);
            setLoading(false);
        }
        loadData();
    }, [groupId]);

    if (loading) return <div className="p-8">Loading...</div>;
    if (!group) return <div className="p-8">Group not found</div>;

    return (
        <div className="flex-1 space-y-8 p-8 pt-6">
            <div className="flex items-center space-x-4">
                <Button variant="ghost" size="icon" asChild>
                    <Link to="/groups">
                        <ArrowLeft className="h-5 w-5" />
                    </Link>
                </Button>
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">{group.name}</h2>
                    <p className="text-muted-foreground">
                        Leader: {group.leaderName}
                    </p>
                </div>
            </div>

            <div className="space-y-4">
                <div className="flex items-center justify-between">
                    <h3 className="text-xl font-semibold">Members</h3>
                    <Button variant="outline" size="sm">Add Member</Button>
                </div>
                <MemberTable members={members} />
            </div>
        </div>
    );
}
