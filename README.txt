# ClassCalSync
# version 0.9
#
# This set of scripts takes data from Veracross's school information 
# management system and creates Google Calendar entires for all of the
# classes and athletic games, complete with (auto-accepted) invites for
# the students and teachers associated with those events and booking
# Google resources (rooms) as appropriate.
#
#
# Copyright 2018 Apu <apu@pingry.org> (Aug. 2018)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# Yes, I write my code in Perl.  Young whipper-snappers and their fancy
# php and python.  I've learned a bunch of languages over the years but
# feel most comfortable in Perl, especially given the CPAN modules, written
# by others, that do most of the heavy lifting for me.  No reason to reinvent
# the wheel.  That said, if you don't like Perl, I hope it is at least close
# enough to pseudo-code for your preferred language that you can translate.



(a) These scripts rely on the "Data Export Packages" module from Veracross to
periodically export data from Axiom and store it on a school-run SFTP server.
Configure your export package as follows:

DATA SOURCES
**************************
* Query 322023: Classes
* Query 322025: Persons-Teachers
* Query 322026: Persons-Students
* Query 322385: Enroll-Teachers
* Query 322386: Enroll-Students
* Query 322389: Events
* Query 359122: Teams
* Query 359243: Athletic-Events

FORMAT & DESTINATION
**************************
Format: CSV
Destination: SFTP



(b) The "do.sh" shell script is run via a cron job to periodically parse
the data received from Veracross, compare it to a local SQL database
where we store info about the events we've sent to Google Calendar,
determine which events we need to add, change or delete from Google
Calendar and then make those changes.

I run this twice a day.  The main run at night captures changes made
during the school day that likely have a lot of resulting calendar
entries.  Examples include a student add/drop for a class, a change
of room, a new class being added, etc. all have tens if not a hundred
events that need to get updated (now through the rest of the year).

Google does throttle their API so it could take hours to run.  In
fact, at the beginning of the school year, this takes close to a
week, though I do stop it for hours at a time when the exponential
back-off is not enough to deal with Google's API quotas.

The second run is early the next morning, just after the school day
is scheduled to start.  This is intended to capture a last minute
alternate block schedule (snow day) and should have a relatively
few number of events that need to be updated.



(c) The "ClassCalSync.sql" file defines the SQL database used to support
this solution.  The tables named with the "cur" prefix hold information
about all the current classes/teams, persons (students & teachers) and
rooms that we are managing.

We also have curEnroll and curEnrollAthl tables that list the people
associated with each class and team, respectively, and the curEvents and
curEventsAthl stores information on all the events (class meetings and
athletic games) that have been pushed to Google Calendar already.  We
use these last four tables, along with the tmp prefixed counterparts,
to determine when we need to add, change or delete events, either
because the enrollment (attendees) for the event has changed or
because the event itself has changed (for example, a change in time
due to an alternate block schedule).

Finally, once we have calculated the differences between the cur and tmp
enrollment and events, we build lists of events that we need toAdd,
toDelete or toUpdate in Google Calendar.

I mention all of this just to document what/why those tables exist.
You should not have to do anything with them other than make sure they
exist and the scripts can access them.  (Except, see (d) below.)



(d) Most of the SQL tables are managed using data we get from Veracross
each time the data export occurs.  The exception is the curRooms table
which is loaded with data either manually, or using the "rooms.pl" script.
If you use the script, we need a "rooms.json" file which you can get from
https://developers.google.com/admin-sdk/directory/v1/reference/resources/calendars/list

All of our rooms and athletic facilities are in Google Calendar as resources.
The names do not have to exactly match the name of the rooms in Veracross
but the curRooms table does need to connect the Veracross room name with the
Google Calendar ID for the room (the ID looks like an e-mail address).

If there is a class, person or room you do not want this script to
push to Google Calendar, just leave it out of the respective SQL table.
For example, if you don't want to book rooms in Google Calendar, just
leave the curRooms table empty.  We won't find a matching room name and
therefore won't invite any room to the events we manage.



(e) The code to interact with Google Calendar is based on 
https://github.com/rjwhite/Google-Calendar-Perl-access which was released
under the GNU General Public License, version 3, and modified by me to fit
my specific needs for this project.

Accordingly, I'm responsible for all errors therein!



(f) The part I can least help you with and have the most PTSD over is the
authentication with Google.  I wish you luck and hereby disclaim any
responsibility for your lack of sleep, loss of hair, chocolate addiction, etc.

But, seriously, I'm not entirely sure what finally worked.  I'm sure it is
documented clearly somewhere but I really feel like I hacked at this problem
with a machete until it finally worked.  Maybe this will help?
https://developers.google.com/admin-sdk/directory/v1/guides/delegation

You're going to need a Google user.  It does not need any Google admin roles,
but is associated with a "connected app."  All of the events you create will
be created by this user and we'll then invite (and accept the invite) for the
people and rooms associated with the events.  (Mine is named "Class Calendar";
very creative, I know.  Your users will see this if they look at the event
details.)

You can create your project and create OAuth 2.0 client IDs and a service
account keys (you need both) via https://console.developers.google.com/

You'll also need to enable API access at 
https://admin.google.com/**school.org**/AdminHome#SecuritySettings:flyout=apimanagement
and grant access to authorized API clients via
https://admin.google.com/**school.org**/AdminHome?chromeless=1#OGX:ManageOauthClients

The API scopes you will need your API client to access are 
https://www.googleapis.com/auth/admin.directory.resource.calendar 
https://www.googleapis.com/auth/calendar 

See also https://cornempire.net/2012/01/08/part-2-oauth2-and-configuring-your-application-with-google/
and the "service_account.pl" script in the "GoogleCalendar" folder.