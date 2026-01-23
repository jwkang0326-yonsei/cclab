
import type { Route } from "./+types/goal-list";

export const meta: Route.MetaFunction = () => {
    return [{ title: "Goals | Admin Web" }];
};

export default function GoalList() {
    return (
        <div className="flex-1 space-y-4 p-8 pt-6">
            <h2 className="text-3xl font-bold tracking-tight">Goals</h2>
            <p>Goal management feature coming soon.</p>
        </div>
    );
}
