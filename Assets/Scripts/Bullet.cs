using System;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    [SerializeField] private ParticleSystem _impactEffect;
    
    private Rigidbody _rigidbody;
    private MeshCollider _meshCollider;

    public void Initialize()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _meshCollider = GetComponent<MeshCollider>();

        _rigidbody.constraints = RigidbodyConstraints.FreezeRotation;
    }

    public void Fire(float speed)
    {
        transform.SetParent(null);
        gameObject.SetActive(true);
        _rigidbody.AddForce(transform.forward * speed, ForceMode.VelocityChange);
    }

    private void OnCollisionEnter(Collision other)
    {
        gameObject.SetActive(false);
        _impactEffect.transform.SetParent(null);

        _impactEffect.transform.position = other.contacts[0].point;
        _impactEffect.transform.eulerAngles = other.contacts[0].normal;

        _impactEffect.Play(true);

        var enemyController = other.collider.GetComponentInParent<EnemyController>();
        if (enemyController != null)
        {
            enemyController.Dead();
        }
    }
}