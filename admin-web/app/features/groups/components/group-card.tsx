
import { Users, User, ArrowRight } from "lucide-react";
import { Link } from "react-router";
import { Button } from "~/core/components/ui/button";

interface GroupCardProps {
    id: string;
    name: string;
    leaderName: string;
    memberCount: number;
}

export function GroupCard({ id, name, leaderName, memberCount }: GroupCardProps) {
    return (
        <div className="rounded-lg border bg-card text-card-foreground shadow-sm p-6 flex flex-col justify-between h-[180px]">
            <div>
                <div className="flex items-center justify-between">
                    <h3 className="text-xl font-bold tracking-tight">{name}</h3>
                    <div className="bg-primary/10 text-primary px-2.5 py-0.5 rounded-full text-xs font-medium flex items-center gap-1">
                        <Users className="h-3 w-3" />
                        {memberCount}
                    </div>
                </div>

                <div className="mt-4 flex items-center gap-2 text-sm text-muted-foreground">
                    <User className="h-4 w-4" />
                    <span>Leader: <span className="font-medium text-foreground">{leaderName}</span></span>
                </div>
            </div>

            <div className="mt-4">
                <Button asChild variant="outline" className="w-full justify-between group">
                    <Link to={`/groups/${id}`}>
                        Manage Group
                        <ArrowRight className="h-4 w-4 ml-2 transition-transform group-hover:translate-x-1" />
                    </Link>
                </Button>
            </div>
        </div>
    );
}
