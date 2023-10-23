# Timezones

Time and date objects have caused issues here in the past. This is meant to
support you if you ever get issues

### Server

The server sends every date and time in UTC. However, this does not represent the time meant.
If the server sends

```json
{
  "startDateTime": "2023-11-06T11:45Z"
}
```

This means it starts at 11:45 local time. I'm not kidding.

### But how do I fiugure out the correct local time of the user? After all, he might have switched timezones!

You don't. I have not yet found any timezone information, but for the meantime, assume
the timezone being **MET**, as this is probably most of Untis' schools timezone.

### What do we do?

If time is irrelevant, use the [date class](/lib/util/date.dart). This helps to prevent
unexpected behaviour due to e. g. leap seconds and daylight savings time.