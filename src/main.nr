use aztec::macros::aztec;

mod test;
mod my_note;

#[aztec]
contract BrokenNoteDemo {

    use aztec::{
        macros::{
            functions::{private, public, initializer},
            storage::storage
        },
        prelude::{ AztecAddress, Map, PrivateMutable, },
    };
    use crate::my_note::MyNoteNote;

    #[storage]
    struct Storage<Context> {
        // note note
        my_note_map: Map<AztecAddress, PrivateMutable<MyNoteNote, Context>, Context>,
    }

    #[public]
    #[initializer]
    fn constructor() {
        //...
    }

    #[private]
    fn make_note(data: Field) {
        let owner = context.msg_sender();
        let mut note_note = MyNoteNote::new(data, owner);
        storage.my_note_map.at(owner).initialize(&mut note_note);
    }

    #[private]
    fn function() {
        let note_owner = context.msg_sender();
        let note_note = storage.my_note_map.at(note_owner).get_note().note;
        assert(note_note.owner == note_owner, "Cannot use note");
        //...
    }

    
}
