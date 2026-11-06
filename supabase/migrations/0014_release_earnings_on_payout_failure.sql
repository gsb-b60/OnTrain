-- Release linked earnings when a payout fails or is cancelled.
--
-- Without this, pt_earnings.payout_id stays set and those earnings are
-- permanently excluded from the PT's available balance. A trigger keeps the
-- recovery path atomic even when an admin updates the payout from the client.
CREATE OR REPLACE FUNCTION public.release_earnings_on_payout_failure()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.status IN ('failed', 'cancelled')
     AND OLD.status IS DISTINCT FROM NEW.status THEN
    UPDATE pt_earnings
       SET payout_id = NULL
     WHERE payout_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_release_earnings_on_payout_failure ON payouts;
CREATE TRIGGER trg_release_earnings_on_payout_failure
AFTER UPDATE OF status ON payouts
FOR EACH ROW
EXECUTE FUNCTION release_earnings_on_payout_failure();
