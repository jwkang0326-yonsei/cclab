
import type { Route } from "./+types/member-list";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Members | Admin Web" }];
};

export default function MemberList() {
    return (
        <div className="flex-1 space-y-4 p-8 pt-6">
            <h2 className="text-3xl font-bold tracking-tight">Members</h2>
            <p>Member management feature coming soon.</p>
        </div>
    );
}
