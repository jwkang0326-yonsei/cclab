
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "~/core/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "~/core/components/ui/avatar";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "~/core/components/ui/select";
import { updateMemberRole } from "../api/groups";
import { toast } from "sonner";
import { useState } from "react";

interface Member {
    id: string;
    name: string;
    email: string;
    role: string;
    avatarUrl?: string;
}

interface MemberTableProps {
    members: Member[];
    onUpdate?: () => void;
}

export function MemberTable({ members, onUpdate }: MemberTableProps) {
    const [updatingId, setUpdatingId] = useState<string | null>(null);

    const handleRoleChange = async (memberId: string, newRole: string) => {
        setUpdatingId(memberId);
        try {
            await updateMemberRole(memberId, newRole);
            toast.success("역할이 변경되었습니다.");
            if (onUpdate) onUpdate();
        } catch (error: any) {
            toast.error(error.message || "역할 변경 중 오류가 발생했습니다.");
        } finally {
            setUpdatingId(null);
        }
    };

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
                                <TableCell>
                                    <Select
                                        disabled={updatingId === member.id}
                                        defaultValue={member.role.toLowerCase()}
                                        onValueChange={(value) => handleRoleChange(member.id, value)}
                                    >
                                        <SelectTrigger className="w-[120px]">
                                            <SelectValue placeholder="Select role" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="member">Member</SelectItem>
                                            <SelectItem value="leader">Leader</SelectItem>
                                            <SelectItem value="admin">Admin</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </TableCell>
                            </TableRow>
                        ))
                    )}
                </TableBody>
            </Table>
        </div>
    );
}
