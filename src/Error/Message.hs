module Error.Message where

import Data.Text       (Text)
import Syntax.Bounds   (Bounds, Pos, WithBounds)

import qualified Syntax.Bounds as B
import Syntax.Lexer.Tokens (Token (TknEOF))
import qualified Data.Text as Text

data ErrorKind
  = UnfinishedString Pos
  | UnrecognizableChar Pos
  | UnexpectedToken (WithBounds Token)
  | UnexpectedAssign Bounds
  deriving (Show)

-- Data Components

data ErrComponent
  = Code Bounds (Maybe Text)
  | Desc Text

data ErrMessage = ErrMessage
  { errBounds :: Maybe Pos,
    errTitle :: Text,
    errComponents :: [ErrComponent]
  }

data ErrReport = ErrReport
  { reportFile :: Text,
    reportContent :: Text,
    reportKind :: ErrorKind
  }

-- Instatiation

onlyCol :: Pos -> Bounds
onlyCol pos@(B.Pos line col) = B.Bounds pos (B.Pos line (col + 1))

columnError :: Pos -> Text -> ErrMessage
columnError pos text = ErrMessage (Just pos) text [Code (onlyCol pos) Nothing]

boundsError :: Bounds -> Text -> ErrMessage
boundsError pos text = ErrMessage (Just $ B.start pos) text [Code pos (Just "Here!")]

messageFromErr :: ErrorKind -> ErrMessage
messageFromErr (UnexpectedToken (B.WithBounds TknEOF pos)) = boundsError pos "Unexpected end of file! "
messageFromErr (UnexpectedToken (B.WithBounds _ pos)) = boundsError pos "Cannot uwndustwand this tUwUken"


messageFromErr (UnfinishedString pos) = columnError pos "Probably you forgot to close a quote while trying to create a string!"
messageFromErr (UnrecognizableChar pos) = columnError pos "Cannot understand this character bro UwU"
messageFromErr (UnexpectedAssign pos) = boundsError pos "You cant use let expressions in the end of a block"