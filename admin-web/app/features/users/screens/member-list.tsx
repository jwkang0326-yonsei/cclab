import type { Route } from "./+types/member-list";
import { useEffect, useState } from "react";
import { fetchAllUsers, type User } from "../api/users";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "~/core/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "~/core/components/ui/avatar";
import { Badge } from "~/core/components/ui/badge";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Members | Admin Web" }];
};

export default function MemberList() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function loadUsers() {
            setLoading(true);
            try {
                const data = await fetchAllUsers();
                setUsers(data);
            } finally {
                setLoading(false);
            }
        }
        loadUsers();
    }, []);

    const getRoleBadge = (role: string) => {
        const r = role.toLowerCase();
        if (r === 'admin' || r === 'super-admin') return <Badge variant="default">{role}</Badge>;
        if (r === 'leader') return <Badge variant="secondary">{role}</Badge>;
        return <Badge variant="outline">{role}</Badge>;
    };

    return (
        <div className="flex-1 space-y-8 p-8 pt-6">
            <div className="flex items-center justify-between">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Members</h2>
                    <p className="text-muted-foreground">
                        Manage all registered users and their permissions.
                    </p>
                </div>
            </div>

            <div className="rounded-md border">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-[80px]">Profile</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>Email</TableHead>
                            <TableHead>Group</TableHead>
                            <TableHead>Role</TableHead>
                            <TableHead>Joined At</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={6} className="h-24 text-center">
                                    Loading members...
                                </TableCell>
                            </TableRow>
                        ) : users.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} className="h-24 text-center">
                                    No members found.
                                </TableCell>
                            </TableRow>
                        ) : (
                            users.map((user) => (
                                <TableRow key={user.id}>
                                    <TableCell>
                                        <Avatar className="h-8 w-8">
                                            <AvatarImage src={user.avatarUrl} alt={user.name} />
                                            <AvatarFallback>{user.name.substring(0, 2).toUpperCase()}</AvatarFallback>
                                        </Avatar>
                                    </TableCell>
                                    <TableCell className="font-medium">{user.name}</TableCell>
                                    <TableCell>{user.email}</TableCell>
                                    <TableCell>{user.groupName}</TableCell>
                                    <TableCell>{getRoleBadge(user.role)}</TableCell>
                                    <TableCell>{user.createdAt}</TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
