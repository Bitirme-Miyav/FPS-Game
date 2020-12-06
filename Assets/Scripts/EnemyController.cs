using RootMotion.Dynamics;
using UnityEngine;

public class EnemyController : MonoBehaviour
{
    [SerializeField] private PuppetMaster _puppetMaster;
    [SerializeField] private Animator _animator;

    public void Dead()
    {
        _puppetMaster.state = PuppetMaster.State.Dead;
        _animator.SetTrigger("dead");
    }
}