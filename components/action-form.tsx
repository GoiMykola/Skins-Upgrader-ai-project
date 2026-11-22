"use client";
import { useActionState, type ReactNode } from "react";
import type { ActionResult } from "@/lib/action-result";

type Action = (previous: ActionResult | null, formData: FormData) => Promise<ActionResult>;

export function ActionForm({
  action,
  children,
  className,
}: {
  action: Action;
  children: ReactNode;
  className?: string;
}) {
  const [result, formAction, pending] = useActionState(action, null);
  return (
    <form action={formAction} className={className}>
      <fieldset disabled={pending} className="contents">
        {children}
      </fieldset>
      {result && result.status >= 400 ? (
        <div role="alert" className="text-sm text-red-500 mt-2 bg-red-500/10 border border-red-500/20 p-2.5 rounded-lg">
          {result.message ? <p className="font-semibold">{result.message}</p> : null}
          {result.fieldErrors
            ? Object.entries(result.fieldErrors).map(([field, text]) => <p key={field} className="text-xs mt-0.5">• {text}</p>)
            : null}
        </div>
      ) : null}
    </form>
  );
}
