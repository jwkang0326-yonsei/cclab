
import { NavLink } from "react-router";
import {
    LayoutDashboard,
    Users,
    Target,
    Settings,
    Group
} from "lucide-react";
import { cn } from "~/core/lib/utils";

interface SidebarProps extends React.HTMLAttributes<HTMLDivElement> { }

export function Sidebar({ className }: SidebarProps) {
    return (
        <div className={cn("pb-12 min-h-screen border-r bg-background", className)}>
            <div className="space-y-4 py-4">
                <div className="px-3 py-2">
                    <h2 className="mb-2 px-4 text-lg font-semibold tracking-tight">
                        Admin Web
                    </h2>
                    <div className="space-y-1">
                        <NavItem to="/dashboard" icon={LayoutDashboard}>
                            Dashboard
                        </NavItem>
                        <NavItem to="/members" icon={Users}>
                            Users
                        </NavItem>
                        <NavItem to="/groups" icon={Group}>
                            Groups
                        </NavItem>
                        <NavItem to="/goals" icon={Target}>
                            Goals
                        </NavItem>
                    </div>
                </div>
                <div className="px-3 py-2">
                    <h2 className="mb-2 px-4 text-lg font-semibold tracking-tight">
                        Settings
                    </h2>
                    <div className="space-y-1">
                        <NavItem to="/settings" icon={Settings}>
                            Settings
                        </NavItem>
                    </div>
                </div>
            </div>
        </div>
    );
}

interface NavItemProps {
    to: string;
    icon: React.ElementType;
    children: React.ReactNode;
}

function NavItem({ to, icon: Icon, children }: NavItemProps) {
    return (
        <NavLink
            to={to}
            className={({ isActive }) =>
                cn(
                    "flex items-center rounded-md px-3 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground transition-colors",
                    isActive ? "bg-accent text-accent-foreground" : "text-muted-foreground"
                )
            }
        >
            <Icon className="mr-2 h-4 w-4" />
            {children}
        </NavLink>
    );
}
