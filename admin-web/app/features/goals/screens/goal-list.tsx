import type { Route } from "./+types/goal-list";
import { useEffect, useState } from "react";
import { fetchGoals, type Goal } from "../api/goals";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "~/core/components/ui/table";
import { Badge } from "~/core/components/ui/badge";
import { Button } from "~/core/components/ui/button";
import { Plus } from "lucide-react";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Goals | Admin Web" }];
};

export default function GoalList() {
    const [goals, setGoals] = useState<Goal[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function loadGoals() {
            setLoading(true);
            try {
                const data = await fetchGoals();
                setGoals(data);
            } finally {
                setLoading(false);
            }
        }
        loadGoals();
    }, []);

    const getStatusBadge = (status: Goal['status']) => {
        switch (status) {
            case 'ACTIVE':
                return <Badge variant="default">Active</Badge>;
            case 'COMPLETED':
                return <Badge variant="secondary">Completed</Badge>;
            case 'ARCHIVED':
                return <Badge variant="outline">Archived</Badge>;
            default:
                return <Badge>{status}</Badge>;
        }
    };

    return (
        <div className="flex-1 space-y-8 p-8 pt-6">
            <div className="flex items-center justify-between space-y-2">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Bible Reading Goals</h2>
                    <p className="text-muted-foreground">
                        Monitor and manage congregational reading goals.
                    </p>
                </div>
                <div className="flex items-center space-x-2">
                    <Button disabled>
                        <Plus className="mr-2 h-4 w-4" /> Create Goal
                    </Button>
                </div>
            </div>

            <div className="rounded-md border">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Title</TableHead>
                            <TableHead>Group</TableHead>
                            <TableHead>Status</TableHead>
                            <TableHead>Period</TableHead>
                            <TableHead className="text-right">Participants</TableHead>
                            <TableHead className="text-right">Progress</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={6} className="h-24 text-center">
                                    Loading goals...
                                </TableCell>
                            </TableRow>
                        ) : goals.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} className="h-24 text-center">
                                    No goals found.
                                </TableCell>
                            </TableRow>
                        ) : (
                            goals.map((goal) => (
                                <TableRow key={goal.id}>
                                    <TableCell className="font-medium">{goal.title}</TableCell>
                                    <TableCell>{goal.groupName}</TableCell>
                                    <TableCell>{getStatusBadge(goal.status)}</TableCell>
                                    <TableCell>
                                        {goal.startDate} ~ {goal.endDate}
                                    </TableCell>
                                    <TableCell className="text-right">{goal.participantCount}</TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex items-center justify-end space-x-2">
                                            <span className="text-sm font-medium">{goal.progress}%</span>
                                            <div className="w-16 h-2 bg-secondary rounded-full overflow-hidden">
                                                <div 
                                                    className="h-full bg-primary" 
                                                    style={{ width: `${goal.progress}%` }}
                                                />
                                            </div>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
