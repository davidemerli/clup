
sig Store {
	queue : lone NumberedTicket,
	slots : lone TimeSlot
}


sig Customer {
} {
	lone t: BookedTicket | t.holder = this
	lone t: VirtualTicket | t.holder = this
	
}

abstract sig Ticket {
	emitted : one TimeStamp
}

sig BookedTicket extends Ticket {
	timeSlot : one TimeSlot,
	holder : one Customer
} {
	precedesStamp[emitted, timeSlot.start]
}

abstract sig NumberedTicket extends Ticket {
	next : lone NumberedTicket
}

sig PhysicalTicket extends NumberedTicket {
	
}

sig VirtualTicket extends NumberedTicket {
	holder: one Customer
}

sig TimeSlot {
	nextSlot : lone TimeSlot,
	start : one TimeStamp,
	end : one TimeStamp
} {
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

fact QueueFlow {
	//Exists a first TimeStamp
	all s: Store | no t: NumberedTicket | t != s.queue and s.queue in t.*next 
	//All timestamps follow the first TimeStamp
	all t: NumberedTicket | one s: Store | s.queue = t or precedesQueue[s.queue, t]
	//No cycles in time
	no t : NumberedTicket | t in t.next.*next
}

fact FirstComeFirstServed {
	all t1: NumberedTicket | all t2: NumberedTicket |
		sameStoreQueue[t1,t2] implies
		(precedesStamp[t1.emitted,t2.emitted] implies precedesQueue[t1,t2])
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

pred inSlot(t: TimeStamp, s: TimeSlot) {
	t = s.start or t = s.end or 
	(precedesStamp[s.start,t] and precedesStamp[t, s.end])
}

pred show {
	#Store = 1
	#TimeSlot > 2
	#NumberedTicket > 4
}

run show for 10
