
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "~/core/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "~/core/components/ui/avatar";

interface Member {
    id: string;
    name: string;
    email: string;
    role: string;
    avatarUrl?: string;
}

interface MemberTableProps {
    members: Member[];
}

export function MemberTable({ members }: MemberTableProps) {
    return (
        <div className="rounded-md border">
            <Table>
                <TableHeader>
                    <TableRow>
                        <TableHead className="w-[100px]">Profile</TableHead>
                        <TableHead>Name</TableHead>
                        <TableHead>Email</TableHead>
                        <TableHead>Role</TableHead>
                    </TableRow>
                </TableHeader>
                <TableBody>
                    {members.length === 0 ? (
                        <TableRow>
                            <TableCell colSpan={4} className="h-24 text-center">
                                No members found.
                            </TableCell>
                        </TableRow>
                    ) : (
                        members.map((member) => (
                            <TableRow key={member.id}>
                                <TableCell>
                                    <Avatar>
                                        <AvatarImage src={member.avatarUrl} alt={member.name} />
                                        <AvatarFallback>{member.name.substring(0, 2).toUpperCase()}</AvatarFallback>
                                    </Avatar>
                                </TableCell>
                                <TableCell className="font-medium">{member.name}</TableCell>
                                <TableCell>{member.email}</TableCell>
                                <TableCell>{member.role}</TableCell>
                            </TableRow>
                        ))
                    )}
                </TableBody>
            </Table>
        </div>
    );
}
