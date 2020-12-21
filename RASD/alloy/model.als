enum Bool {False, True}

sig Store {
	//List of all numbered tickets in order of issue time
	queue : lone NumberedTicket, 
	//List of all bookable timeslots
	slots : lone TimeSlot, 
	inside: set Customer
}


sig Customer {
} {
	//A customer retrieves only one ticket (Simplification)
	lone t: Ticket | t.holder = this
}

abstract sig Ticket {
	issued : one TimeStamp, 
	used : lone TimeStamp,  
	noShow : one Bool,
	holder : one Customer
} {
	//A ticket must be used after his issue
	isUsed[this] implies precedesStamp[issued, used]
	//If the customer doesn't show the ticket is not used
	noShow = True implies not isUsed[this] 
}

sig BookedTicket extends Ticket {
	timeSlot : one TimeSlot,
} {
	//A ticket must be booked before the slot starts
	precedesStamp[issued, timeSlot.start]
	//A ticket must be used within his slot
	precedesStamp[timeSlot.end, used] or used = timeSlot.start or noShow = True
	precedesStamp[used, timeSlot.end] or used = timeSlot.end or noShow = True
}

abstract sig NumberedTicket extends Ticket {
	next : lone NumberedTicket
}

sig PhysicalTicket extends NumberedTicket {}

sig VirtualTicket extends NumberedTicket {}

sig TimeSlot {
	nextSlot : lone TimeSlot,
	start : one TimeStamp,
	end : one TimeStamp
} {
    //The time slot end has a greater timestamp that the slot's start timestamp
	precedesStamp[start,end]
}

sig TimeStamp {
	nextStamp : lone TimeStamp
}

fact timeFlow {
	//Exists a first TimeStamp
	one first : TimeStamp | no t: TimeStamp | t != first and first in t.*nextStamp 
	//All timestamps follow the first TimeStamp
	one first : TimeStamp | all t: TimeStamp | t != first implies precedesStamp[first, t]
	//No cycles in time
	no t : TimeStamp | t in t.nextStamp.*nextStamp
}

fact slotFlow {
	//Exists a first TimeStamp
	all s: Store | no t: TimeSlot | t != s.slots and s.slots in t.*nextSlot 
	//All timestamps follow the first TimeStamp
	all t: TimeSlot | one s: Store | s.slots = t or precedesSlot[s.slots, t]
	//No cycles in time
	no t : TimeSlot | t in t.nextSlot.*nextSlot
}

fact timeSlotNotOverlapping {
	//Previous Starts and ends before, no Overlaps
	all s1: TimeSlot | all s2 : TimeSlot |
        sameStoreSlot[s1,s2] implies 
		(precedesSlot[s1,s2] 
		iff (precedesStamp[s1.start, s2.start] and 
			 precedesStamp[s1.end, s2.end] and
			 precedesStamp[s1.end, s2.start]))
}

fact queueFlow {
	//Exists a first TimeStamp
	all s: Store | no t: NumberedTicket | t != s.queue and s.queue in t.*next 
	//All timestamps follow the first TimeStamp
	all t: NumberedTicket | one s: Store | s.queue = t or precedesQueue[s.queue, t]
	//No cycles in time
	no t : NumberedTicket | t in t.next.*next
}

fact firstComeFirstServed {
	//A ticket with a smaller timestamp is ahead in the queue
	all t1: NumberedTicket | all t2: NumberedTicket |
		sameStoreQueue[t1,t2] implies
		(precedesStamp[t1.issued,t2.issued] implies precedesQueue[t1,t2])
	//A customer enters the store only if all people before him have entered the store or no-showed
	all s: Store | all t1: NumberedTicket | all t2: NumberedTicket |
		(inStoreQueue[s,t1] and inStoreQueue[s,t2] and precedesQueue[t1,t2]) implies
		((t2.holder in s.inside) implies (t1.holder in s.inside or t1.noShow = True))
}

fact ticketNeededToEnter {
	//No one could enter without a ticket
	all s : Store | all c : Customer | c in s.inside iff (one t: Ticket | t.holder = c  and isUsed[t]) 
}


pred isUsed(t: Ticket) {
	#t.used = 1
}


pred precedesStamp(t1, t2: TimeStamp) {
	t2 in t1.nextStamp.*nextStamp
} 


pred precedesSlot(t1, t2: TimeSlot) {
	t2 in t1.nextSlot.*nextSlot
}

pred sameStoreSlot (t1, t2: TimeSlot) {
	precedesSlot[t1,t2] or precedesSlot[t2,t1] or t1 = t2
}

pred sameStoreQueue (t1, t2: NumberedTicket) {
	precedesQueue[t1,t2] or precedesQueue[t2,t1] or t1 = t2
}

pred precedesQueue(t1, t2: NumberedTicket) {
	t2 in t1.next.*next
}

pred inStoreQueue(s : Store, t : NumberedTicket) {
	t = s.queue or precedesQueue[s.queue,t]
}

pred inSlot(t: TimeStamp, s: TimeSlot) {
	t = s.start or t = s.end or 
	(precedesStamp[s.start,t] and precedesStamp[t, s.end])
}

pred show {
	
}

//RUN
run show for 7 but 10 TimeStamp
