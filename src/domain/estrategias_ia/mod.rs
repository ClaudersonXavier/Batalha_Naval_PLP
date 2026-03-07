pub mod facil;
pub mod intermediaria;

use crate::domain::disparo::RetornoDisparo;
use crate::domain::tabuleiro::EstadoTabuleiro;

pub trait EstrategiaIA {
    fn escolher_alvo(&mut self, tabuleiro_inimigo: &EstadoTabuleiro) -> Option<(usize, usize)>;
    fn notificar_resultado(&mut self, _x: usize, _y: usize, _resultado: &RetornoDisparo) {}
}

pub use facil::EstrategiaFacil;
pub use intermediaria::EstrategiaIntermediaria;
